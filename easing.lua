function shake(count, duration, total)
  local p = (duration / total * count) % 1
  if p < 0.25 then
    return p * 4
  elseif p < 0.5 then
    return 1 - (p - 0.25) * 4
  elseif p < 0.75 then
    return (0.5 - p) * 4
  else
    return -1 + (p - 0.75) * 4
  end
end

return {
  shake = shake,
}
